if require("libs.cache")["clang_lsp_cpp"] then
  return
end

require("lang").run_lsp("clangd", {})
