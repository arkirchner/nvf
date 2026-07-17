{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) bool enum listOf package;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.tex;
  defaultServers = ["texlab"];
  servers = ["texlab" "ltex-plus"];

  defaultFormat = ["tex-fmt"];
  formats = ["tex-fmt" "latexindent"];
in {
  options.vim.languages.tex = {
    enable = mkEnableOption "TeX language support";

    treesitter = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableTreesitter;
        defaultText = literalExpression "config.vim.languages.enableTreesitter";
        description = "Enable TeX treesitter";
      };
      latexPackage = mkGrammarOption pkgs "latex";
      bibtexPackage = mkGrammarOption pkgs "bibtex";
    };

    lsp = {
      enable =
        mkEnableOption "TeX LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        description = "TeX LSP server to use";
        type = listOf (enum servers);
        default = defaultServers;
      };

      package = mkOption {
        type = package;
        default = pkgs.ltex-ls-plus;
        description = "ltex-ls-plus package";
      };
    };

    format = {
      enable =
        mkEnableOption "TeX formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "TeX formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.latexPackage
        cfg.treesitter.bibtexPackage
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["plaintex" "tex" "bib"];
        }) // {
          ltex-plus = {
            cmd = ["${cfg.lsp.package}/bin/ltex-ls-plus"];
            filetypes = ["bib" "context" "gitcommit" "html" "markdown" "org" "pandoc" "plaintex" "quarto" "mail" "mdx" "rmd" "rnoweb" "rst" "tex" "text" "typst" "xhtml" "ruby"];
            settings = {
              ltex = {
                language = "en-US";
                additionalRules = {
                  enablePickyRules = true;
                };
                enabled = ["bib" "context" "gitcommit" "html" "markdown" "org" "pandoc" "plaintex" "quarto" "mail" "mdx" "rmd" "rnoweb" "rst" "tex" "latex" "text" "typst" "xhtml" "ruby"];
              };
            };
          };
        };
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft = {
          tex = cfg.format.type;
          plaintex = cfg.format.type;
        };
      };
    })
  ]);
}
