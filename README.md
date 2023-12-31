## SBarOverride

Make fun with iOS status bar elements!

Tested on 6s+ iOS 15.8. Notched devices may/might not work.

Icon by me - I was a fool doing corner radius tasks so forgive me for that

## Build

1. Install theos.

2. Setup RemoteLog: https://github.com/Muirey03/RemoteLog (optional)

3. Build:

    ```bash
    $ [environment variable=value] make [target]
    ```

    Use THEOS_PACKAGE_SCHEME=rootless for a rootless build,
    DEBUG_RLOG=1 to use RemoteLog.

## References

This tweak was made better with the help of:

* RyanNair with his Little12 tweak - its source code helped me fixed my respring function

* SourceLoc's [blog](blog.sourceloc.net) for his RemoteLog & clock tweak guide. Also @Muirey03 for RemoteLog.

* NightWindDev & iPhone Development Wiki for settings cell documentation.