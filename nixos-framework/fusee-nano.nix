{ stdenv, lib, fetchFromGitHub, xxd, util-linux, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "fusee-nano";
  version = "0.5.3";

  src = fetchFromGitHub {
  owner = "DavidBuchanan314";
  repo = "fusee-nano";
  rev = "${version}";
  hash = "sha256-nUduW6/k0gvKedV5SUfb6pDIk2esJ6dUTTr/NcQnzbs=";
  };

  buildInputs = [ util-linux ];
  nativeBuildInputs = [ makeWrapper xxd ];

  installPhase = ''
    mkdir -p $out/bin
    cp fusee-nano $out/bin
    wrapProgram $out/bin/fusee-nano \
      --prefix PATH : ${lib.makeBinPath [ util-linux ]}
  '';

  meta = with lib; {
    description = "A minimalist re-implementation of the Fusée Gelée exploit, designed to run on embedded Linux devices. (Zero dependencies)";
    homepage = "https://github.com/DavidBuchanan314/fusee-nano";
    license = licenses.mit;
    platforms = platforms.linux;
    mainprogram = "fusee-nano";
  };
}
