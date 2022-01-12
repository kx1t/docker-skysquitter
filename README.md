# docker-skysquitter
 a Docker container to feed SkySquitter with Beast data

## What is it?
SkySquitter collects ADS-B data from feeders like dump1090/dump1090-fa/readsb/tar1090 and creates a weather map based on this. The service is experimental. More information is available at https://www.skysquitter.com/

## How to feed?
In order to feed your data to SkySquitter, you must have an existing ADS-B receiver that provides data in "BEAST" format. Any modern version of `dump1090(-fa)`,`readsb`, or `tar1090` will be able to do so. Most stations have BEAST data enabled by default, but in exceptional situations you may have to configure your existing setup so it makes BEAST format data available on a TCP port.

### Docker container feeder
This is the preferred way for anyone who has Docker running on their system. A Multi Architecture container is available for the following architectures: `armhf` (32-bits Raspberry Pi), `arm64` (64-bits Raspberry Pi), `amd64` (PC (Intel/AMD) Linux), `i386` (MacOS). Note that only the `armhf` and `arm64` images are tested. Feel free to open an (https://github.com/kx1t/docker-skysquitter/issues)[issue] if you come across a bug.

To configure an use `SkySquitter`, please add the following entry to your `docker-compose.yml` file:
```
  skysquitter:
    image: kx1t/skysquitter
    tty: true
    container_name: skysquitter
    hostname: skysquitter
    restart: always
    depends_on:
      - readsb
    environment:
      - SKYSQUITTER_SOURCE=readsb:30005
      - SKYSQUITTER_DEST=airdata.skysquitter.com:xxxxx
      - TZ=${FEEDER_TZ}
    tmpfs:
      - /var/log
```
In this entry, please review and replace the following parameter with values that are appropriate for your setup:
| Parameter   | Definition                    | Value                     |
|-------------|-------------------------------|---------------------------|
| `SKYSQUITTER_SOURCE` | This is where your BEAST data comes from. Format is `host:port`. Note that you cannot use `localhost` or `127.0.0.1` for this; you must use the container name for your source host, or alternatively the IP address of your host station. | If omitted, default value of `readsb:30005` is assumed. |
| `SKYSQUITTER_DEST` | This is the hostname and port that was provided to you by SkySquitter. Format is `host:port`. If you don't know this value, please contact info@skysquitter.com to obtain one.| No default value, must be user provided.

### Stand-alone feeder
For stations that do not use Docker, we have created a short BASH script. Note - you will need the Linux BASH shell to run this, so it won't natively work in Windows or MacOS.
Do the following (assuming Linux with BASH and `systemd` available, which is the case on Raspberry Pi and most PC Linux systems):
```
sudo mkdir /usr/share/skysquitter
sudo wget -q -O /usr/share/skysquitter/skysquitter.sh https://raw.githubusercontent.com/kx1t/docker-skysquitter/main/scripts/skysquitter_standalone.sh
sudo wget -q -O /etc/systemd/system/skysquitter.service https://raw.githubusercontent.com/kx1t/docker-skysquitter/main/scripts/skysquitter.service
sudo chmod a+rx /usr/share/skysquitter /usr/share/skysquitter/skysquitter.sh
```
Then edit the service file and change this line to insert your specific data. You must obtain a port number (to replace `xxxxx`) from SkySquitter before you can use the service. You can also update `localhost:30005` if your source BEAST data comes from another machine or a different port.
(Note - easiest way to edit is by typing `sudo nano /etc/systemd/system/skysquitter.service`. Make your edits and save/exit with `CTRL-X y`).
```
ExecStart=/bin/bash /usr/share/skysquitter/skysquitter.sh airdata.skysquitter.com:xxxxx localhost:30005
```
Then start the service with this command:
```
sudo systemctl enable skysquitter # this enables the SkySquitter service at every reboot
sudo systemctl start skysquitter  # this starts SkySquitter immediately without waiting for the next reboot
systemctl status skysquitter      # this shows the status of SkySquitter
```

# QUESTIONS?

Note that the author of this container and of the stand-alone script is NOT related to SkySquitter. He simply wrote a short script that takes data from a BEAST source and sends this to SkySquitter.

- For SkySquitter related questions, please contact info@skysquitter.com
- For questions about this repository, the container, script, etc., please contact kx1t@amsat.org or open an (https://github.com/kx1t/docker-skysquitter/issues)[issue] in the repository.

# OWNERSHIP AND LICENSE
SkySquitter is owned by, and copyright by SkySquitter. All rights reserved.
Contact info@SkySquitter.com for more information.

The software, scripts, and data of this repository were created by kx1t and are licensed under the Gnu Public License, version 3.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
