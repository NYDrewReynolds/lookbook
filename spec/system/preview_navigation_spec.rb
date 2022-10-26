require "rails_helper"

RSpec.describe "preview navigation", type: :system do
  before do
    visit lookbook_home_path
  end

  context "preview without annotations" do
    context "with multiple examples" do
      let(:preview) { Lookbook.previews.find_by_id(:unannotated) }
      let(:examples) { preview.examples }
      let(:preview_item_selector) { "#previews-nav-unannotated" }

      context "has preview link" do
        it "rendered as a group" do
          within("#previews-nav") do
            expect(page).to have_css("#{preview_item_selector}[data-entity-type=preview]")
          end
        end

        it "with an autogenerated label" do
          expect(page).to have_css(preview_item_selector, text: "Unannotated")
        end

        it "is closed by default" do
          expect(page).to have_css("#{preview_item_selector} > [x-ref=items]", visible: false)
        end

        it "can be toggled to hide/show the examples links" do
          button = find("#{preview_item_selector} button")

          [true, false].each do |visible|
            button.click
            expect(page).to have_css("#{preview_item_selector} > [x-ref=items]", visible: visible)
          end
        end
      end

      context "has examples" do
        it "with links within the preview item" do
          within(preview_item_selector) do
            examples.each do |example|
              expect(page).to have_css("#previews-nav-#{example.id}[data-entity-type=example] a", visible: false)
            end
          end
        end

        it "with autogenerated labels" do
          examples.each do |example|
            expect(page).to have_css("#previews-nav-#{example.id}", text: example.name.titleize, visible: false)
          end
        end

        it "which each link to the appropriate example" do
          find("#{preview_item_selector} button").click
          examples.each do |example|
            find("#previews-nav-#{example.id} a").click
            expect(page).to have_css("[data-preview-target=#{example.id}]")
          end
        end
      end
    end

    context "with a single example" do
      let(:preview) { Lookbook.previews.find_by_id(:single_unannotated_example) }
      let(:preview_item_selector) { "#previews-nav-single-unannotated-example" }

      context "has preview link" do
        it "rendered as a example" do
          within("#previews-nav") do
            expect(page).to have_css("#{preview_item_selector}[data-entity-type=example]")
          end
        end

        it "with an autogenerated label based on the preview name" do
          expect(page).to have_css(preview_item_selector.to_s, text: "Unannotated")
        end

        it "which links to the example" do
          find("#{preview_item_selector} a").click

          expect(page).to have_css("[data-preview-target=#{preview.default_example.id}]")
        end
      end

      it "does not display the example as a child item" do
        within(preview_item_selector) do
          expect(page).not_to have_css("[x-ref=items]", visible: false)
          expect(page).not_to have_css("[x-ref=items]", visible: true)
          expect(page).not_to have_css("#previews-nav-#{preview.default_example.id}", visible: false)
        end
      end
    end
  end

  context "annotated preview" do
    let(:preview) { Lookbook.previews.find_by_id(:annotated_test) }
    let(:examples) { preview.examples }
    let(:preview_item_selector) { "#previews-nav-annotated-test" }

    context "has preview link" do
      it "with an custom label" do
        expect(page).to have_css(preview_item_selector, text: "Annotated Label")
      end
    end

    context "has visible examples" do
      let(:visible_examples) { examples.select { |example| !example.hidden? } }

      it "with links within the preview item" do
        within(preview_item_selector) do
          visible_examples.each do |example|
            expect(page).to have_css("#previews-nav-#{example.id}[data-entity-type=example] a", visible: false)
          end
        end
      end

      it "with labels set by the label tag when present" do
        visible_examples.each do |example|
          expect(page).to have_css("#{preview_item_selector}-#{example.name.tr("_", "-")}",
            text: example.tag(:label)&.value || example.name.titleize,
            visible: false)
        end
      end

      it "which each link to the appropriate example" do
        find("#{preview_item_selector} button").click
        visible_examples.each do |example|
          find("#previews-nav-#{example.id} a").click
          expect(page).to have_css("[data-preview-target=#{example.id}]")
        end
      end
    end

    it "does not display hidden examples" do
      hidden_examples = examples.select { |example| example.hidden? }

      hidden_examples.each do |example|
        expect(page).not_to have_css("#previews-nav-#{example.id}", visible: false)
        expect(page).not_to have_css("#previews-nav-#{example.id}", visible: true)
      end
    end
  end
end
