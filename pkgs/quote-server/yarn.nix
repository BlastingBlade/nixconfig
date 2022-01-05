{ fetchurl, fetchgit, linkFarm, runCommand, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "unique_random_array___unique_random_array_3.0.0.tgz";
      path = fetchurl {
        name = "unique_random_array___unique_random_array_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/unique-random-array/-/unique-random-array-3.0.0.tgz";
        sha1 = "db0c11c885d674c39050a79cf25d11b09ff97c22";
      };
    }
    {
      name = "unique_random___unique_random_3.0.0.tgz";
      path = fetchurl {
        name = "unique_random___unique_random_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/unique-random/-/unique-random-3.0.0.tgz";
        sha1 = "ddf20e62d2f5af1dbd606602fb5b5821588c8469";
      };
    }
  ];
}
