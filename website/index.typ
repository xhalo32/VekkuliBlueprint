// https://github.com/typst/typst/issues/7223#issuecomment-3446402111

/// Produce default document information needed for `default-head`. Requires
/// context.
#let get-document-info() = (
  title: document.title,
  author: document.author,
  description: document.description,
  keywords: document.keywords,
)

/// Produces default head HTML tag based on document information.
///
/// ```typ
/// #show: doc => context html.html(default-head(get-document-info())() + doc)
/// ```
///
/// - info (dictionary): Document information that is passed to the head tag.
///     Use `get-document-info`.
#let default-head(info) = (..args) => {
  let head = if args.pos().len() > 0 { args.pos().first() } else { none }
  html.head(..args.named(), {
    html.meta(charset: "utf-8")
    html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
    // html.style(read("test.css"))
    html.style(read("styles.css"))
    if info.title != none {
      html.title(info.title)
    }
    if info.description != none {
      html.meta(name: "description", content: info.description.text)
    }
    if info.author.len() != 0 {
      html.meta(name: "authors", content: info.author.join(", "))
    }
    if info.keywords.len() != 0 {
      html.meta(name: "keywords", content: info.keywords.join(", "))
    }
    head
  })
}

#show: it => context {
  let head = default-head(get-document-info())
  html.html(head() + html.body(it, style: "margin: 0; padding: 0;"))
}

#show block: it => html.elem("div", attrs: (style: "padding:" + str(it.inset.length.to-absolute().pt()) + "px;"), it)

#show align: it => {
  if it.alignment == center {
    html.elem("div", attrs: (style: "margin-left: auto; margin-right: auto; text-align: center;"), it.body)
  }
}

// #show heading: it => block(inset: 0.2em, it)

#let fix-style(it) = {
  let color = text.fill.to-hex()
  let size = text.size.to-absolute().pt()
  let attrs = html.elem.attrs
  let old-style = attrs.at("style", default: none)
  let style = "color: " + color + "; font-size: " + str(size) + "px;"
  let merged-attrs = (..attrs, style: old-style + style)
  set html.elem(attrs: merged-attrs, it)

  it
}

// TODO is there a way to avoid repetition?

#show text: fix-style
#show heading: fix-style

// Content starts here

#set text(1.2em)

#html.elem(
  "section",
  attrs: (style: "background-image: linear-gradient(120deg, #155799, #159957); padding: 2em 1em;"),
  align(center)[
    #show heading: it => {
      set text(size: 2em)
      set html.elem(attrs: (style: "margin: 0em;"))
      it
    }

    #set text(white)
    = Vektorianalyysi

    #set text(white.transparentize(30%))
    Niklas Halonen, Alma Nevalainen

    #html.a(class: "btn", href: "https://xhalo32.github.io/VekkuliBlueprint/blueprint/")[
      Blueprint
    ]
    #html.a(class: "btn", href: "https://github.com/xhalo32/VekkuliBlueprint")[
      GitHub
    ]
    #html.a(class: "btn", href: "https://xhalo32.github.io/VekkuliBlueprint/blueprint/print.pdf")[
      Print
    ]
  ],
)

#show: html.article.with(style: "width: min(100vw, 500px); margin: 0 auto;")

#set text(fill: black.lighten(15%))

Tämä projekti on Vektorianalyysi-kurssin aikana kehitetty luuranko vektorianalyysin formalisointia varten.
Löydät materiaalin painamalla *Blueprint*-painikkeesta, joka vie sinut #link("https://github.com/PatrickMassot/leanblueprint")[leanblueprint]-työkalulla luotuun dokumenttiin, josta löydät kätevän verkkomaisen rakenteen kurssin määritelmistä ja tuloksista (#link("./blueprint/dep_graph_document.html")[Dependency graph]).

Päälähde on #link("https://helda.helsinki.fi/items/983661c5-d242-4e33-88b6-c5a3663276f4")[Olli Martio: Vektorianalyysi], mutta projekti sisältää myös tuloksia Sauli Lindbergin luennoiman Vektorianalyysi II kurssin luentomonisteesta.
