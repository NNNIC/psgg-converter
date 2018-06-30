cd /d %~dp0
echo namespace psggConverterLib { public class ver { public static readonly string version="0.6.0";    public static readonly string datetime="%DATE%-%TIME%"; } } > ver.cs