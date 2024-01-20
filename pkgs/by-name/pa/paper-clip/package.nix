{ lib
, desktop-file-utils
, exempi
, fetchFromGitHub
, glib
, gtk4
, libadwaita
, meson
, ninja
, pkg-config
, poppler
, stdenv
, vala
, wrapGAppsHook4
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "paper-clip";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "Diego-Ivan";
    repo = "Paper-Clip";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8RZE6YzoJ98D++w7v007cdurMdfZoX3oQvN94F1d9cI=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    exempi
    glib
    gtk4
    libadwaita
    poppler
  ];

  meta = with lib; {
    changelog = "https://github.com/Diego-Ivan/Paper-Clip/releases/tag/v${finalAttrs.version}";
    description = "Edit PDF document metadata";
    homepage = "https://github.com/Diego-Ivan/Paper-Clip";
    license = licenses.gpl3Plus;
    mainProgram = "pdf-metadata-editor";
    maintainers = with maintainers; [ michaelgrahamevans ];
    platforms = platforms.linux;
  };
})
