{ final, prev }:

prev.mkYarnPackage rec {
  pname = "quote-server";
  version = "1.0.0";

  src = final.fetchFromGitHub {
    owner = "BlastingBlade";
    repo = "quote-server";
    rev = "${version}";
    sha256 = "sha256-YCkBgMKnBHjsm5nvQlO/h+dWK90gu9q1pQM8hT3cGgc=";
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
