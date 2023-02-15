{ lib
, rustPlatform
, fetchFromGitHub
, stdenv
, installShellFiles
, installShellCompletions ? stdenv.hostPlatform == stdenv.buildPlatform
, installManPages ? stdenv.hostPlatform == stdenv.buildPlatform
, pkg-config
, Security
, libiconv
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "himalaya";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "soywod";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-yAfNH9LSXlS/Hzi5kAuur5BX2vITMucprDzxhlV8RiY=";
  };

  cargoSha256 = "sha256-FXfh6T8dNsnD/V/wYSMDWs+ll0d1jg1Dc3cQT39b0ws=";

  nativeBuildInputs = [ ]
    ++ lib.optionals (installManPages || installShellCompletions) [ installShellFiles ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ pkg-config ];

  buildInputs =
    if stdenv.hostPlatform.isDarwin then [
      Security
      libiconv
    ] else [
      openssl
    ];

  # TODO: remove this flag once this issue is fixed:
  # https://todo.sr.ht/~soywod/pimalaya/36
  cargoTestFlags = [ "--lib" ];

  postInstall = lib.optionalString installManPages ''
    # Install man pages
    mkdir -p $out/man
    $out/bin/himalaya man $out/man
    installManPage $out/man/*
  '' + lib.optionalString installShellCompletions ''
    # Install shell completions
    installShellCompletion --cmd himalaya \
      --bash <($out/bin/himalaya completion bash) \
      --fish <($out/bin/himalaya completion fish) \
      --zsh <($out/bin/himalaya completion zsh)
  '';

  meta = with lib; {
    description = "Command-line interface for email management";
    homepage = "https://github.com/soywod/himalaya";
    changelog = "https://github.com/soywod/himalaya/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ soywod toastal yanganto ];
  };
}
