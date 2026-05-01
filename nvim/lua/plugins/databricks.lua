return {
  {
    "natori-hrj/databricks.nvim",
    ft = "python",
    config = function()
      require("databricks").setup({
        profile = "DEFAULT",
        cluster_id = nil,
        upload_path = "dbfs:/tmp/databricks-nvim",
        poll_interval_ms = 5000,
        output_position = "botright",
        output_height = 15,
      })
    end,
    keys = {
      { "<leader>dr", "<cmd>DatabricksRun<cr>", desc = "Databricks: Run file" },
      { "<leader>dc", "<cmd>DatabricksClusterSelect<cr>", desc = "Databricks: Select cluster" },
      { "<leader>dl", "<cmd>DatabricksClusterList<cr>", desc = "Databricks: List clusters" },
      { "<leader>do", "<cmd>DatabricksOutput<cr>", desc = "Databricks: Show output" },
    },
  },
}
