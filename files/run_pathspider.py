#!/usr/bin/python3
# vim: expandtab ts=4 syntax=python

from pyroute2 import IPRoute
from urllib.request import urlopen
import subprocess
import time
import logging

class MONROESpider:

    def __init__(self):
        logger = logging.getLogger("monroespider")

        self.ip = IPRoute()

        all_ifnames = [self._get_link_ifname(link)
                       for link in self.ip.get_links()]

        # We don't want to mess with metadata or loopback interfaces
        self.ifnames = [ifname for ifname in all_ifnames
                        if not ifname.startswith("lo") and
                        ifname is not "metadata"]
        logger.info("Got interfaces: " + str(self.ifnames))

        self.active_ifname = None

    def _get_link_ifname(self, link):
        logger = logging.getLogger("monroespider")

        for attr in link['attrs']:
            if attr[0] == "IFLA_IFNAME":
                return attr[1]
        else:
            # This should never happen.
            raise Exception("An interface didn't have a name. "
                            "Don't know how to cope with this.")

    def set_exclusive_interface(self, desired_ifname):
       logger = logging.getLogger("monroespider")

       # Set all interfaces down except the one we want
       for ifname in self.ifnames:
           idx = self.ip.link_lookup(ifname=ifname)[0]
           if ifname == desired_ifname:
               self.ip.link('set', index=idx, state='up')
           else:
               self.ip.link('set', index=idx, state='down')

       # Wait for some time (may not be necessary)
       time.sleep(30)

       # Attempt to retrieve helper data
       try:
           helper = urlopen("https://erg.abdn.ac.uk/whereami.php").read()
       except:
           logger.error("Attempting to set exclusive interface {} failed! "
                        "Could not retrieve helper data."
                        .format((ifname,)))
           self.active_ifname = None
           self.data = None
           return False

       # Write out the helper data, adding the interface
       data = json.loads(helper.decode('utf-8'))
       data['active_ifname'] = ifname
       logger.debug("Helper information was {}".format((str(data),)))
       with open("/tmp/helper-" + exclusive_link + ".json", "w") as output:
           output.write(json.dumps(data))

       # Things have gone well, set the state
       self.active_ifname = ifname
       self.data = data
       return True

monroe = MONROESpider()

for ifname in monroe.ifnames:
    monroe.set_exclusive_interface(ifname)
    subprocess.call(['pathspider', '-i', link, '/usr/share/doc/pathspider/examples/webtest.csv', '/tmp/output-' + link + '.txt'])
    subprocess.call(['mv', '/tmp/output-' + link + '.ndjson', '/monroe/results'])

