# LocalTools Gentoo

LocalTools packaging for Gentoo.

## Usage

### Manual way

Create the `/etc/portage/repos.conf/localtools.conf` file as follows:

```
[localtools]
priority = 50
location = /var/db/repos/localtools
sync-type = git
sync-uri = https://github.com/MeRkyLeZ/LocalTools.git
auto-sync = Yes
```

Then run `emaint sync -r localtools`, Portage should now find and update the repository.

### Eselect way

On terminal:

```bash
sudo eselect repository add localtools git https://github.com/MeRkyLeZ/LocalTools.git
```

And then run `emaint sync -r localtools`, Portage should now find and update the repository.
