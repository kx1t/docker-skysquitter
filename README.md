# docker-skysquitter
 a Docker container to feed SkySquitter with Beast data

## What is it?
SkySquitter collects ADS-B data from feeders like dump1090/dump1090-fa/readsb/tar1090 and creates a weather map based on this. The service is experimental. More information is available at https://www.skysquitter.com/

## Feeding SkySquitter
Skysquitter uses crowd-sourced data on an invitation-only basis. If you think you would like to contribute, please contact info@SkySquitter.com.

##SkySquitter container configuration

The SkySquitter container retrieves ADS-B data in Beast format from your (separate) decoder application and feeds it to the SkySquitter service.
This is done using a small Java application that converts data retrieved via a TCP/IP link to a connection-less UDP data stream.
The data is sent securely via a WireGuard VPN that is also part of the container. The VPN is set up in such a way that the SkySquitter Service has access to the data from the SkySquitter container, but not to any other container in your stack. 

Configuration of SkySquitter has the following prerequisites:
- a Linux machine (PC, Raspberry Pi, etc.) with a functioning Docker configuration
- we strongly recommend using `docker-compose` to manage your container

Using the example [`docker-compose.yml`](docker-compose.yml) file, please configure the following parameters. Unless told otherwise by SkySquitter, please do not modify any of the other parameters:

|---|----|
|`WG_PRIVKEY`|Private Key provided by SkySquitter |
|`WG_PSK`|PSK Key provided by SkySquitter|
|`MY_IP`|Ip address provided by SkySquitter|
|`RECV_HOST`| Domain Name or IP address of your Beast format ASDB decoder|
|`RECV_PORT`| TCP Port of your Beast format ASDB decoder (probably 30005)|

# OWNERSHIP AND LICENSE
SkySquitter is owned by, and copyright by SkySquitter. All rights reserved.
Contact info@SkySquitter.com for more information.

The package includes software by WireGuard, and docker wrappers by LinuxServer. These are licensed under the Gnu Public License, version 3.

The software, scripts, and data of this repository were created by kx1t and are licensed under the Gnu Public License, version 3.

The Java beast-feeder.jar is a module that is provided by, and copyright by SkySquitter.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
