{ lib }:

lib // (with lib; rec {
  mkEnableDefault = desc: mkEnableOption desc // { default = true; };
})
