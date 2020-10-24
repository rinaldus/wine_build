You can compile almost any* version of vanilla wine or wine-staging.
# Instructions
1. Clone this repository to any directory. Open `wine_build.sh` in text editor and change `WORKDIR` and `MAKEOPTS` variables.
2. Make the script executable
    `chmod +x wine_build.sh`
3. Launch the script with wine version number as parameter. For example:
    `./wine_build.sh 5.20`
    After script work is finished, you can find .tar.gz archive with your build in `WORKDIR/install/`
# Disclaimer
You can't build stable (.0) wine versions with this script because of different source paths for stable (e.g 5.0) and unstable (e.g 5.x) versions.
*I don't gurantee that this script can build any old wine version with this script. I don't care about it. I care about only latest wine major branch.
