class PagesController < ApplicationController
  def home
    set_meta_tags(
      title: "Luxury Slow Fashion | Handmade Designer Clothing",
      description: "Discover Shers Studios, the home of luxury slow fashion and handmade bespoke designs. Shop exclusive collections featuring avant-garde shapes and premium materials like latex, wool felt, and deadstock fabrics.",
      og: {
        title: "Luxury Slow Fashion | Handmade Designer Clothing",
        description: "Discover Shers Studios, the home of luxury slow fashion and handmade bespoke designs. Shop exclusive collections featuring avant-garde shapes and premium materials like latex, wool felt, and deadstock fabrics."
      }
    )
  end

  def about
    set_meta_tags(
      title: "Learn About Sustainable Luxury Fashion",
      description: "Explore Shers Studios’ exclusive collection of luxury avant-garde fashion. Shop handmade latex dresses, skirts, and limited-edition bespoke designs, all crafted with slow fashion principles in mind.",
      og: {
        title: "Learn About Sustainable Luxury Fashion",
        description: "Explore Shers Studios’ exclusive collection of luxury avant-garde fashion. Shop handmade latex dresses, skirts, and limited-edition bespoke designs, all crafted with slow fashion principles in mind."
      }
    )
  end

  def contact
  end

  def faq
    set_meta_tags(
      title: "FAQ | Slow Designer Fashion",
      description: "The most important questions about slow fashion, latex care and made-to-order answered.",
      og: {
        title: "FAQ | Slow Designer Fashion",
        description: "The most important questions about slow fashion, latex care and made-to-order answered."
      }
    )
  end

  def explore
    set_meta_tags(
      title: "Explore Independent Designer Fashion",
      description: "Immerse yourself in Shers Studios’ collection of independent luxury fashion. Discover bespoke avant-garde designs that challenge the boundaries of slow and sustainable fashion.",
      og: {
        title: "Explore Independent Designer Fashion",
        description: "Immerse yourself in Shers Studios’ collection of independent luxury fashion. Discover bespoke avant-garde designs that challenge the boundaries of slow and sustainable fashion."
      }
    )
  end

  def privacy
    set_meta_tags(
      title: "Privacy Policy",
      description: "Learn how Shers Studios protects your personal data. Our Privacy Policy ensures transparency for customers of our bespoke fashion collections, in accordance with the latest regulations.",
      og: {
        title: "Privacy Policy",
        description: "Learn how Shers Studios protects your personal data. Our Privacy Policy ensures transparency for customers of our bespoke fashion collections, in accordance with the latest regulations."
      }
    )
  end

  def terms
    set_meta_tags(
      title: "Terms & Conditions | Ethical and Unique Fashion",
      description: "Review the Terms and Conditions of Shers Studios, including our policies on custom orders, shipping, returns, and exchanges for bespoke luxury garments.",
      og: {
        title: "Terms & Conditions | Ethical and Unique Fashion",
        description: "Review the Terms and Conditions of Shers Studios, including our policies on custom orders, shipping, returns, and exchanges for bespoke luxury garments."
      }
    )
  end
end
