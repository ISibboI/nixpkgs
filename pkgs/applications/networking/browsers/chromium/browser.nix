{ stdenv, mkChromiumDerivation }:

with stdenv.lib;

mkChromiumDerivation (base: rec {
  name = "chromium-browser";
  buildTargets = [ "chrome" ];

  installPhase = ''
    ensureDir "$libExecPath"
    cp -v "$buildPath/"*.pak "$libExecPath/"
    cp -v "$buildPath/icudtl.dat" "$libExecPath/"
    cp -vR "$buildPath/locales" "$buildPath/resources" "$libExecPath/"
    cp -v $buildPath/libffmpegsumo.so "$libExecPath/"

    cp -v "$buildPath/chrome" "$libExecPath/$packageName"

    mkdir -vp "$out/share/man/man1"
    cp -v "$buildPath/chrome.1" "$out/share/man/man1/$packageName.1"

    for icon_file in chrome/app/theme/chromium/product_logo_*[0-9].png; do
      num_and_suffix="''${icon_file##*logo_}"
      icon_size="''${num_and_suffix%.*}"
      expr "$icon_size" : "^[0-9][0-9]*$" || continue
      logo_output_prefix="$out/share/icons/hicolor"
      logo_output_path="$logo_output_prefix/''${icon_size}x''${icon_size}/apps"
      mkdir -vp "$logo_output_path"
      cp -v "$icon_file" "$logo_output_path/$packageName.png"
    done
  '';

  meta = {
    description = "An open source web browser from Google";
    homepage = http://www.chromium.org/;
    maintainers = with maintainers; [ goibhniu chaoflow aszlig wizeman ];
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
})
