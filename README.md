# metAaRCive-explorer

This is the repo for the R shiny app for exploring the [metAaRCive](https://github.com/AaRC-Animal-aDNA-Research-Community/metAaRCive) database, a resource of metadata for published ancient animal genomes curated by members of [AaRC](https://animal-adna.org/).

The app is hosted here: https://aarc.shinyapps.io/metaarcive/

Thanks go to [Harry Gordon](https://github.com/HGord2022) for developing the original app!

## Repository structure and files

- `metAaRCive/`
  - `rsconnect/` - Deployment configuration for the Shiny app
  - `www/` - Directory for images and other assets to be used in the app
  - `app.R` - Main script for the R Shiny app
  - `get_df.R` - Downloads and filters the latest version of the database from the metAaRCive [repo](https://github.com/AaRC-Animal-aDNA-Research-Community/metAaRCive)
  - `aarc_metadata.csv` - Dataframe generated from `get_df.R`
