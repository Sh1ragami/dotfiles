-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.clipboard = "unnamedplus"
vim.opt.conceallevel = 0 -- 勝手に文字を隠したり置換したりするのを無効化
vim.g.tex_conceal = "" -- 特にTeXファイルなどで記号が置換されるのを防ぐ
