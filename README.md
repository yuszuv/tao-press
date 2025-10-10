# LPV Contao <> Wordpress Mapper

a ruby service, that extracts the news feed from a contao instance and turns
it into a .csv ready to be imported into a wordpress installation.

## running it

Give it the URL of the contao DB and run

```
```
export DATABASE_URL=mysql://user:password@localhost:3306/lpv-contao
bin/extract.rb
```
```
