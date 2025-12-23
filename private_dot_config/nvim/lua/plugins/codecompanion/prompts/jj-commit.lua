return {
  diff = function(ctx)
    local remote_bookmark = vim.fn.input "remote bookmark"
    return vim
      .system(
        { "jj", "diff", "--no-pager", "-r", string.format("remote_bookmarks(substring:%s)", remote_bookmark) },
        { text = true }
      )
      :wait().stdout
  end,
}
