{ final, prev }:

prev.mkYarnPackage rec {
  pname = "quote-server";
  version = "1.0.1";

  src = final.fetchFromGitHub {
    owner = "BlastingBlade";
    repo = "quote-server";
    rev = "${version}";
    sha256 = "sha256-TZPVJjQ8vpwloazKvkqgfEdAlU3sBpSyGFaalTWQPCw=";
  };

  yarnFlags = [ "--offline" "--production" ];
  yarnLock = ./yarn.lock;
  packageJSON = ./package.json;
  yarnNix = ./yarn.nix;

  meta = with prev.lib; {
    description = "Host application to display rotating quotes on an eletric sign";
    homepage = "https://github.com/BlastingBlade/quote-server";
    platforms = platforms.unix;
  };
}
