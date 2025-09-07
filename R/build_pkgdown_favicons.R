#' A local alternative to [pkgdown::build_favicons]
#'
#' The list of returned icons is exactly the same as
#' [pkgdown::build_favicons()], to allow this function to be used as a drop-in
#' replacement.
#'
#' @inheritParams pkgdown::build_favicons
#'
#' @export
build_pkgdown_favicons <- function(pkg = ".", overwrite = FALSE) {
  out_path <- file.path(pkg, "pkgdown", "favicon")

  if (dir.exists(out_path) && !overwrite) {
    cli::cli_inform(c(
      "Favicons already exist in {.path pkgdown}",
      i = "Set {.code overwrite = TRUE} to re-create."
    ))
    return(invisible())
  }

  logo_path <- pkgdown:::find_logo(pkg)

  if (is.null(logo_path)) {
    cli::cli_abort(c(
      "Can't find package logo PNG or SVG to build favicons.",
      i = "See {.fun usethis::use_logo} for more information."
    ))
  }

  if (endsWith(logo_path, ".svg")) {
    logo <- magick::image_read_svg(logo_path, width = 4096, height = 4096)
    file.copy(
      logo_path,
      file.path(out_path, "favicon.svg")
    )
  } else {
    logo <- magick::image_read(logo_path)

    # Embed raster as base64 in svg
    system.file("template.svg", package = "pkgicon") |>
      read_file() |>
      whisker::whisker.render(
        list(base64_png = jsonlite::base64_enc(magick::image_write(logo)))
      ) |>
      writeLines(
        file.path(out_path, "favicon.svg")
      )
  }

  magick::image_scale(logo, "180x180") |>
    magick::image_write(
      file.path(out_path, "apple-touch-icon.png"),
      format = "png"
    )
  magick::image_scale(logo, "96x96") |>
    magick::image_write(
      file.path(out_path, "favicon-96x96.png"),
      format = "png"
    )
  magick::image_scale(logo, "192x192") |>
    magick::image_write(
      file.path(out_path, "web-app-manifest-192x192.png"),
      format = "png"
    )
  magick::image_scale(logo, "512x512") |>
    magick::image_write(
      file.path(out_path, "web-app-manifest-512x512.png"),
      format = "png"
    )

  # ico
  ico <- c(
    magick::image_scale(logo, "16x16"),
    magick::image_scale(logo, "32x32"),
    magick::image_scale(logo, "48x48")
  )
  magick::image_write(
    ico,
    file.path(out_path, "favicon.ico"),
    format = "ico"
  )

  manifest <- list(
    # In the future, set this to the pkg name. But pkgdown::build_favicons()
    # doesn't set it so this is not a regression.
    name = "",
    short_name = "",
    icons = list(
      list(
        src = "/web-app-manifest-192x192.png",
        sizes = "192x192",
        type = "image/png", # nolint: nonportable_path_linter.
        purpose = "maskable"
      ),
      list(
        src = "/web-app-manifest-512x512.png",
        sizes = "512x512",
        type = "image/png", # nolint: nonportable_path_linter.
        purpose = "maskable"
      )
    ),
    theme_color = "#ffffff",
    background_color = "#ffffff",
    display = "standalone"
  )
  jsonlite::write_json(
    manifest,
    file.path(out_path, "site.webmanifest"),
    auto_unbox = TRUE,
    pretty = TRUE
  )

  cli::cli_inform(c(v = "Added {.path {sort(path_file(paths))}}."))
  invisible()
}
