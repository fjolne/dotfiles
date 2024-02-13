lib: {
  utils = {
    readSecretFile = path:
      let skip = builtins.getEnv "SKIP_SECRETS"; in
      assert (skip == "" || skip == "0" || skip == "1");
      if skip == "1" then "" else builtins.readFile path;
  };
}
