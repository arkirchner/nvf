{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package enum;
  inherit (lib.nvim.types) deprecatedSingleOrListOf;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.tex;

  defaultServers = [ "ltex-plus" ];
  servers = {
    "ltex-plus" = {
      cmd = [ "${cfg.lsp.package}/bin/ltex-ls-plus" ];
      filetypes = [ "bib" "context" "gitcommit" "html" "markdown" "org" "pandoc" "plaintex" "quarto" "mail" "mdx" "rmd" "rnoweb" "rst" "tex" "text" "typst" "xhtml" "ruby" ];
      settings = {
        ltex = {
          language = "en-US";
          additionalRules = {
            enablePickyRules = true;
          };
          enabled = [ "bib" "context" "gitcommit" "html" "markdown" "org" "pandoc" "plaintex" "quarto" "mail" "mdx" "rmd" "rnoweb" "rst" "tex" "latex" "text" "typst" "xhtml" "ruby" ];
        };
      };
    };
  };
in
{
  options.vim.languages.tex = {
    enable = mkEnableOption "Tex support and more";

    lsp = {
      enable = mkEnableOption "Tex LSP support (ltex-ls-plus)" // {
        default = config.vim.lsp.enable;
      };

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.tex.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Tex LSP server to use";
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers."${n}";
        })
        cfg.lsp.servers;
    })
  ]);
}
