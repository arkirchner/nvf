{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.tex;
in
{
  options.vim.languages.tex = {
    enable = mkEnableOption "Tex support and more";

    lsp = {
      enable = mkEnableOption "Tex LSP support (ltex-ls-plus)" // {
        default = config.vim.lsp.enable;
      };

      package = mkOption {
        type = package;
        default = pkgs.ltex-ls-plus;
        description = "ltex-ls-plus package";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.ltex-ls-plus = ''
        lspconfig.ltex_plus.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          filetypes = { "bib", "context", "gitcommit", "html", "markdown", "org", "pandoc", "plaintex", "quarto", "mail", "mdx", "rmd", "rnoweb", "rst", "tex", "text", "typst", "xhtml", "ruby" },
          settings = {
            ltex = {
              language = "en-US",
              additionalRules = {
                enablePickyRules = true,
              },
              enabled = { "bib", "context", "gitcommit", "html", "markdown", "org", "pandoc", "plaintex", "quarto", "mail", "mdx", "rmd", "rnoweb", "rst", "tex", "latex", "text", "typst", "xhtml", "ruby" }
            }
          },
          cmd = {"${cfg.lsp.package}/bin/ltex-ls-plus"},
        }
      '';
    })
  ]);
}
