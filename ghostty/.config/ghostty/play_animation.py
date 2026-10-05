#!/usr/bin/env python3

"""Stream a transparent video as successive Kitty graphics placements."""

import base64
import secrets
import subprocess
import sys
import time


PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
ESC = b"\x1b"
ST = ESC + b"\\"
CHUNK_SIZE = 4096
FPS = 24
# Remove the ghosted transition frame, then keep the 60px reframe at its original position.
FRAME_POSITION_FILTER = (
    "select='not(eq(n,57))',"
    "setpts=N/(24*TB),"
    "tpad=stop=1:stop_mode=clone,"
    "pad=720:600:0:60:color=black@0,"
    "crop=720:480:0:'60-if(gte(t,2.375),60,0)'"
)


def read_exact(stream, size):
    chunks = bytearray()
    while len(chunks) < size:
        chunk = stream.read(size - len(chunks))
        if not chunk:
            raise EOFError("truncated PNG frame")
        chunks.extend(chunk)
    return bytes(chunks)


def read_png(stream):
    signature = stream.read(len(PNG_SIGNATURE))
    if not signature:
        return None
    if signature != PNG_SIGNATURE:
        raise ValueError("ffmpeg did not produce a PNG frame")

    png = bytearray(signature)
    while True:
        header = read_exact(stream, 8)
        length = int.from_bytes(header[:4], "big")
        data_and_crc = read_exact(stream, length + 4)
        png.extend(header)
        png.extend(data_and_crc)
        if header[4:] == b"IEND":
            return bytes(png)


def send_png(png, image_id, columns, rows, z_index, placement_id=1):
    payload = base64.b64encode(png)
    chunks = [payload[i : i + CHUNK_SIZE] for i in range(0, len(payload), CHUNK_SIZE)]
    out = sys.stdout.buffer

    for index, chunk in enumerate(chunks):
        more = int(index < len(chunks) - 1)
        if index == 0:
            header = (
                f"\x1b_Ga=T,f=100,i={image_id},p={placement_id},c={columns},r={rows},"
                f"z={z_index},C=1,q=1,m={more};"
            ).encode()
        else:
            header = f"\x1b_Gm={more},q=1;".encode()
        out.write(header + chunk + ST)

    out.flush()


def delete_image(image_id):
    sys.stdout.buffer.write(f"\x1b_Ga=d,d=I,i={image_id},q=1".encode() + ST)
    sys.stdout.buffer.flush()


def main():
    if len(sys.argv) != 10:
        return 2

    video = sys.argv[1]
    image_columns = max(1, int(sys.argv[2]))
    image_rows = max(1, int(sys.argv[3]))
    text_video = sys.argv[4]
    text_image = sys.argv[5]
    text_columns = max(1, int(sys.argv[6]))
    text_rows = max(1, int(sys.argv[7]))
    text_column = max(1, int(sys.argv[8]))
    text_row = max(1, int(sys.argv[9]))

    sys.stdout.buffer.write(b"\x1b_Ga=d,d=A,q=1" + ST + b"\x1b[2J\x1b[H\x1b[?25l")
    sys.stdout.buffer.write(b"\x1b[1;1H")
    sys.stdout.buffer.flush()

    command = [
        "ffmpeg",
        "-nostdin",
        "-hide_banner",
        "-loglevel",
        "error",
        "-i",
        video,
        "-vf",
        FRAME_POSITION_FILTER,
        "-an",
        "-f",
        "image2pipe",
        "-vcodec",
        "png",
        "-pix_fmt",
        "rgba",
        "pipe:1",
    ]

    try:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    except OSError:
        return 1

    image_id = secrets.randbelow(3_000_000_000) + 1
    previous_id = None
    frame_number = 0
    started = None
    text_process = None

    try:
        while True:
            png = read_png(process.stdout)
            if png is None:
                break

            if started is None:
                started = time.monotonic()
            else:
                target = started + frame_number / FPS
                delay = target - time.monotonic()
                if delay > 0:
                    time.sleep(delay)

            current_id = (image_id + frame_number) % 4_294_967_295 + 1
            send_png(png, current_id, image_columns, image_rows, frame_number + 1)
            if previous_id is not None:
                delete_image(previous_id)

            previous_id = current_id
            frame_number += 1

        return_code = process.wait()
        if return_code != 0 or frame_number == 0:
            return 1

        text_command = [
            "ffmpeg",
            "-nostdin",
            "-hide_banner",
            "-loglevel",
            "error",
            "-i",
            text_video,
            "-an",
            "-f",
            "image2pipe",
            "-vcodec",
            "png",
            "-pix_fmt",
            "rgba",
            "pipe:1",
        ]
        text_process = subprocess.Popen(
            text_command, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL
        )
        text_image_id = (image_id + frame_number + 1) % 4_294_967_295 + 1
        previous_text_id = None
        text_frame_number = 0
        text_started = None

        while True:
            png = read_png(text_process.stdout)
            if png is None:
                break

            if text_started is None:
                text_started = time.monotonic()
            else:
                target = text_started + text_frame_number / FPS
                delay = target - time.monotonic()
                if delay > 0:
                    time.sleep(delay)

            current_id = (text_image_id + text_frame_number) % 4_294_967_295 + 1
            sys.stdout.buffer.write(f"\x1b[{text_row};{text_column}H".encode())
            sys.stdout.buffer.flush()
            send_png(
                png,
                current_id,
                text_columns,
                text_rows,
                frame_number + 1,
                placement_id=2,
            )
            if previous_text_id is not None:
                delete_image(previous_text_id)

            previous_text_id = current_id
            text_frame_number += 1

        text_return_code = text_process.wait()
        if text_return_code != 0 or text_frame_number == 0:
            return 1

        with open(text_image, "rb") as text_file:
            text_png = text_file.read()
        sys.stdout.buffer.write(f"\x1b[{text_row};{text_column}H".encode())
        sys.stdout.buffer.flush()
        final_text_id = (text_image_id + text_frame_number) % 4_294_967_295 + 1
        send_png(
            text_png,
            final_text_id,
            text_columns,
            text_rows,
            frame_number + 1,
            placement_id=2,
        )
        if previous_text_id is not None:
            delete_image(previous_text_id)
    except (BrokenPipeError, EOFError, OSError, ValueError):
        if text_process is not None:
            text_process.kill()
            text_process.wait()
        process.kill()
        process.wait()
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
