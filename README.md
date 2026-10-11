# metAaRCive-explorer

This is the repo for the R shiny app for exploring the [metAaRCive](https://github.com/AaRC-Animal-aDNA-Research-Community/metAaRCive) database, a resource of metadata for published ancient animal genomes curated by members of [AaRC](https://animal-adna.org/).

The app is hosted here: https://aarc.shinyapps.io/metaarcive/

Thanks go to [Harry Gordon](https://github.com/HGord2022) for developing the original app!

## Repository structure and files

- `renv/` - R environment for automatic deployment
- `rsconnect/` - Deployment configuration for the Shiny app
- `www/` - Directory for images and other assets to be used in the app
- `app.R` - Main script for the R Shiny app
- `renv.lock` - R environment lock file for automatic deployment

## Developer notes

### Deployment

After pushing new changes, the server needs to be redeployed to reflect the changes.

At the moment, only [@DeondeJager](https://github.com/DeondeJager) is authenticated to do this, but the plan is to implement automatic deployment via GitHub Actions in future.

For now, ask [@DeondeJager](https://github.com/DeondeJager) to re-deploy if any changes are made until auto deployment has been implemented.

**Deployment process**:

- Clone/pull repo to local machine.
- Open `app.R` in Rstudio and run the following code:

```
library(rsconnect)
deployApp()
```
