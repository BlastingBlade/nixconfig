{ inputs }:

final: prev: {
  quote-server = prev.callPackage ./quote-server { inherit final prev; };
}
