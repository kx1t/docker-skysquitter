# docker-skysquitter
 a Docker container to feed SkySquitter with Beast data

## What is it?
SkySquitter collects ADS-B data from feeders like dump1090/dump1090-fa/readsb/tar1090 and creates a weather map based on this. The service is experimental. More information is available at [https://www.skysquitter.com](https://www.skysquitter.com).

## Feeding SkySquitter
**Skysquitter uses crowd-sourced data on a very limited, invitation-only basis. If you think you would like to contribute, please contact info@SkySquitter.com.**

## SkySquitter container configuration

The SkySquitter container retrieves ADS-B data in Beast format from your (separate) decoder application and feeds it to the SkySquitter service.
This is done using a small Java application that converts data retrieved via a TCP/IP link to a connection-less UDP data stream.
The data is sent securely via a WireGuard VPN that is also part of the container. The VPN is set up in such a way that the SkySquitter Service has access to the data from the SkySquitter container, but not to any other container in your stack.

Configuration of SkySquitter has the following prerequisites:

- a Linux machine (PC, Raspberry Pi, etc.) with a functioning Docker configuration. See [here](https://github/com/sdr-enthusiasts/docker-install) for some help on how to get this done quickly.
- we strongly recommend using `docker-compose` to manage your container

Using the example [`docker-compose.yml`](docker-compose.yml) file, please configure the following parameters. Unless told otherwise by SkySquitter, please do not modify any of the other parameters:

### Mandatory variables:
| Variable     | Description                                                 |
|--------------|-------------------------------------------------------------|
| `WG_PRIVKEY` | Private Key provided by SkySquitter                         |
| `WG_PSK`     | PSK Key provided by SkySquitter                             |
| `MY_IP`      | Ip address provided by SkySquitter                          |

Note - these variables will be provided to you by SkySquitter. Under specific circumstances, SkySquitter may provide you with a `wg0.conf` file instead,
that you can install as described in the [Configuration Alternatives](#configuration-alternatives) section below.

### Optional variables:
Note -- these variables generally do NOT need changing unless you are using a non-standard setup.
If your ADS-B generating container or host is not `readsb`, please make sure to set the `RECV_HOST` parameter!

| Variable          | Description                                                                         | Default value if omitted |
|-------------------|-------------------------------------------------------------------------------------|--------------------------|
| `RECV_HOST`       | Domain Name or IP address of your Beast format ASDB decoder                         | `readsb`                 |
| `RECV_PORT`       | TCP port on `RECV_HOST` where Beast-format data is available                        | `30005`                  |
| `DEST_HOST`       | Hostname or IP address of SkySquitter Server                                        | `10.9.2.1`               |
| `DEST_PORT`       | UDP port on SkySquitter Server to send data to                                      | `11092`                  |
| `FAILURE_TIMEOUT` | Max DEST_HOST and RECV_HOST failure time before corrective measures are taken (secs)| `150`                    |
| `PRUNE_INTERVAL`  | Interval for log file pruning                                                       | `12h`                    |
| `PRUNE_SIZE`      | Maximum number of log lines left when pruning log files                             | `1000`                   |
| `BEASTDEV`        | If defined, download the latest `beast-feeder.py` from the dev branch of the [skysquitter22/beast-feeder](https://github.com/skysquitter22/beast-feeder) repo. You can also define a different repo by putting the `raw` URL of the beast-feeder.py file as value to this parameter. | (not defined) |
| `SET_TIMESTAMP`   | If set to TRUE/ON/ENABLED, the system will send timestamped data to the server. Note -- please only enable this if your system clock is GPS or NTP enabled and your container time is set to UTC | (not defined) |

## How do I know if things work?
There are several ways to figure out if things are working.
Note - in the commands below, we are assuming that your SkySquitter container is named `ssq`. If you named it differently, please adapt the command accordingly.

| What              | How                                                    | Description                                                                                                                                                                                                                                                                        |
|-------------------|--------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Container logs    | `docker logs -f ssq`                                   | The container logs provide a comprehensive view of everything that is happening: initial setup, config, parameters when running, etc. This may sometimes be a bit overwhelming - see below for more focused analytical tools.                                                      |
| Monitor           | `docker exec -it ssq monitor`                          | This command will analyze the data flow between the Beast Host and the Server. If omitted, the `interval` is `3` secs and the `repeats` is `5` times. Any result that shows a non-zero packet count captured or received means that data is flowing from Beast Host to the Server. |
| Ping Beast Source | `docker exec -it ssq pingbeast`                        | This command will attempt to ping your Beast Source to see if it can be reached.                                                                                                                                                                                                   |
| Ping Server       | `docker exec -it ssq pingserver`                       | This command will attempt to ping the SkySquitter Server to see if it can be reached.                                                                                                                                                                                              |
| Watchdog logs     | `docker exec -it ssq cat /var/log/feeder-watchdog.log` | This will show you up to 1000 lines of the Watchdog Logs. If nothing is shown, the logs are empty and the watchdog never had to take corrective action.                                                                                                                            |

## Troubleshooting
The SkySquitter container is reasonably "self-correcting": if your Beast Host or the SkySquitter network cannot be reached, it will take progressive steps to try to remedy the issue.
The container restart itself if that is the case.
If problems continue, then this has probably to do with your setup. Make sure that the `capadd` and `sysctl` sections are present in your [`docker-compose.yml`](docker-compose.yml) file and use the [example](docker-compose.yml) in this repo as your starting point.
Make sure that the `WG_PRIVKEY`, `WG_PSK`, and `MY_IP` variables are set *exactly* as instructed by SkySquitter.

## Configuration Alternatives

In some circumstances, SkySquitter may ask you to install a special "`wg0.conf`" network configuration.
In that case, some of the environment variables from `docker-compose.yml` will be ignored by the container.

To install this `wg0.conf` file:

1. Go to the directory where your `docker-compose.yml` file is located. If you use the default values, you can do `cd /opt/adsb`
2. Initialize the container with `docker-compose up -d` - this will ensure that the mapped volume `/opt/adsb/skysquitter` is created and linked to the container.
3. Immediately stop the container again with `docker-compose stop ssq`
4. Copy the `wg0.conf` file into place. If the file is in the home directory of your local machine, you can do this with `sudo cp ~/wg0.conf /opt/adsb/skysquitter`
5. Restart the container stack with `docker-compose up -d`

## OWNERSHIP AND LICENSE
SkySquitter is owned by, and copyright by SkySquitter. All rights reserved.
Contact info@SkySquitter.com for more information.

The software, scripts, and data of this repository were created by kx1t and are licensed under the [MIT License](LICENSE).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
