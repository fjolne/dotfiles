lib: {
  utils = {
    readSecretFile = path:
      if (builtins.getEnv "SKIP_SECRETS" == "true") then ""
      else builtins.readFile path;
  };
}
