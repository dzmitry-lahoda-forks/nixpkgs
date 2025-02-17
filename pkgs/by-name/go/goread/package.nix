{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "goread";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "TypicalAM";
    repo = "goread";
    rev = "v${version}";
    hash = "sha256-8QjroS0aKALcrDJkpihD70iJJBdiVP4Q2j2n3BsY71w=";
  };

  vendorHash = "sha256-S/0uuy/G7ZT239OgKaOT1dmY+u5/lnZKL4GtbEi2zCI=";

  env.TEST_OFFLINE_ONLY = 1;

  meta = {
    description = "Beautiful program to read your RSS/Atom feeds right in the terminal";
    homepage = "https://github.com/TypicalAM/goread";
    changelog = "https://github.com/TypicalAM/goread/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "goread";
    maintainers = with lib.maintainers; [ schnow265 ];
  };
}
