-- leetcode.nvim の保存先を「問題ごとのディレクトリ」構成に変えて Git で管理するための拡張。
--
-- <storage.home>/<id>.<title-slug>/
--   ├── README.md    問題文（LeetCode から自動生成、毎回上書き）
--   ├── answer.md    解答メモ（初回だけ雛形を作り、以降は手を入れない）
--   └── solution.go  解答コード（leetcode.nvim が直接読み書きする実体）

local M = {}

local ENTITIES = {
  ["&lt;"] = "<",
  ["&gt;"] = ">",
  ["&quot;"] = '"',
  ["&apos;"] = "'",
  ["&nbsp;"] = " ",
  ["&amp;"] = "&",
}

local function decode_entities(html)
  return (html:gsub("&#(%d+);", function(code)
    return vim.fn.nr2char(tonumber(code))
  end):gsub("&%a+;", function(entity)
    return ENTITIES[entity] or entity
  end))
end

-- pandoc が無い環境向けの簡易変換。LeetCode の問題文で使われるタグだけ扱う。
local function fallback_markdown(html)
  local md = html
    :gsub("\r\n", "\n")
    -- コードブロック内はマークアップせず、タグだけ落とす
    :gsub("<pre[^>]*>%s*(.-)%s*</pre>", function(code)
      return "\n```\n" .. (code:gsub("<[^>]*>", "")) .. "\n```\n"
    end)
    :gsub("<code[^>]*>(.-)</code>", "`%1`")
    :gsub("<strong[^>]*>(.-)</strong>", "**%1**")
    :gsub("<b[^>]*>(.-)</b>", "**%1**")
    :gsub("<em[^>]*>(.-)</em>", "*%1*")
    :gsub("<i[^>]*>(.-)</i>", "*%1*")
    :gsub("[ \t]*<li[^>]*>%s*", "- ")
    :gsub("</li>", "")
    :gsub("<br%s*/?>", "\n")
    :gsub("</p>", "\n")
    :gsub("<[^>]*>", "")
    :gsub("\n\n\n+", "\n\n")

  return decode_entities(md)
end

---@param html string
---@return string
local function html_to_markdown(html)
  if not html or html == "" or html == vim.NIL then
    return "_(問題文を取得できませんでした)_"
  end

  if vim.fn.executable("pandoc") == 1 then
    local res = vim
      .system({ "pandoc", "--from=html", "--to=gfm", "--wrap=none" }, { stdin = html, text = true })
      :wait(10000)

    if res.code == 0 and res.stdout and res.stdout ~= "" then
      return (vim.trim(res.stdout:gsub("\r\n", "\n")))
    end
  end

  return vim.trim(fallback_markdown(html))
end

---@param q lc.question_res
---@return Path
function M.question_dir(q)
  local config = require("leetcode.config")
  return config.storage.home:joinpath(("%s.%s"):format(q.frontend_id, q.title_slug))
end

---@param q lc.question_res
local function question_url(q)
  local config = require("leetcode.config")
  return ("https://leetcode.%s/problems/%s/"):format(config.domain, q.title_slug)
end

---@param q lc.question_res
local function readme_content(q)
  local lines = {
    ("# %s. %s"):format(q.frontend_id, q.title),
    "",
    ("- 難易度: %s"):format(q.difficulty),
    ("- URL: %s"):format(question_url(q)),
  }

  if type(q.topic_tags) == "table" and not vim.tbl_isempty(q.topic_tags) then
    local tags = vim.tbl_map(function(tag)
      return ("`%s`"):format(tag.name)
    end, q.topic_tags)
    table.insert(lines, ("- タグ: %s"):format(table.concat(tags, ", ")))
  end

  if type(q.stats) == "table" and q.stats.acRate then
    table.insert(lines, ("- Acceptance: %s"):format(q.stats.acRate))
  end

  vim.list_extend(lines, { "", "## 問題", "", html_to_markdown(q.content) })

  if type(q.hints) == "table" and not vim.tbl_isempty(q.hints) then
    vim.list_extend(lines, { "", "## ヒント", "", "<details>", "<summary>開く</summary>", "" })
    for i, hint in ipairs(q.hints) do
      table.insert(lines, ("%d. %s"):format(i, html_to_markdown(hint)))
    end
    vim.list_extend(lines, { "", "</details>" })
  end

  return table.concat(lines, "\n") .. "\n"
end

---@param q lc.question_res
---@param lang string
local function answer_template(q, lang)
  return table.concat({
    ("# %s. %s"):format(q.frontend_id, q.title),
    "",
    ("- 解いた日: %s"):format(os.date("%Y-%m-%d")),
    ("- 言語: %s"):format(lang),
    "- 結果: <!-- Accepted / TLE / WA など -->",
    "",
    "## アプローチ",
    "",
    "## 考えた過程",
    "",
    "## 計算量",
    "",
    "- 時間: O()",
    "- 空間: O()",
    "",
    "## つまずいた点・学び",
    "",
    "## 別解・改善案",
    "",
  }, "\n")
end

--- 従来のフラットなファイル（<id>.<slug>.<ext>）があれば新ディレクトリへ移す
---@param q lc.question_res
---@param lang lc.language
---@param dest Path
local function migrate_flat_file(q, lang, dest)
  local config = require("leetcode.config")
  local alt = lang.alt and ("." .. lang.alt) or ""

  local candidates = {
    ("%s.%s-%s.%s"):format(q.frontend_id, q.title_slug, lang.slug, lang.ft),
    ("%s.%s%s.%s"):format(q.frontend_id, q.title_slug, alt, lang.ft),
  }

  for _, name in ipairs(candidates) do
    local old = config.storage.home:joinpath(name)
    if old:exists() then
      local ok = vim.uv.fs_rename(old:absolute(), dest:absolute())
      if ok then
        return true
      end
    end
  end

  return false
end

--- leetcode.nvim の解答ファイル配置を問題ごとのディレクトリに変更する
local function patch_question_path()
  local Question = require("leetcode-ui.question")
  local utils = require("leetcode.utils")

  ---@return string path, boolean existed
  function Question:path()
    local lang = utils.get_lang(self.lang)
    local alt = lang.alt and ("." .. lang.alt) or ""

    local dir = M.question_dir(self.q)
    dir:mkdir({ parents = true, exists_ok = true, mode = 493 }) -- 0755

    self.file = dir:joinpath(("solution%s.%s"):format(alt, lang.ft))

    local existed = self.file:exists() or migrate_flat_file(self.q, lang, self.file)
    if not existed then
      self.file:write(self:snippet(), "w")
    end

    return self.file:absolute(), existed
  end
end

--- question_enter フックから呼ぶ。README.md と answer.md を用意する。
---@param question lc.ui.Question
function M.on_question_enter(question)
  local q = question.q
  if not q then
    return
  end

  local dir = M.question_dir(q)
  dir:mkdir({ parents = true, exists_ok = true, mode = 493 })

  dir:joinpath("README.md"):write(readme_content(q), "w")

  local answer = dir:joinpath("answer.md")
  if not answer:exists() then
    answer:write(answer_template(q, question.lang), "w")
  end
end

--- 開いている問題の answer.md を縦分割で開く
function M.open_note()
  local ok, question = pcall(require("leetcode.utils").curr_question)
  if not ok or not question or not question.q then
    return
  end

  vim.cmd("vsplit " .. vim.fn.fnameescape(M.question_dir(question.q):joinpath("answer.md"):absolute()))
end

local patched = false

--- `enter` フックから呼ぶ（storage が初期化されたあとである必要がある）
function M.setup()
  if patched then
    return
  end

  patch_question_path()
  patched = true
end

return M
