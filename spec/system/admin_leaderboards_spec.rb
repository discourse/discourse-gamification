# frozen_string_literal: true

describe "Admin leaderboards", type: :system, js: true do
  fab!(:current_user) { Fabricate(:admin) }

  before do
    SiteSetting.discourse_gamification_enabled = true
    sign_in(current_user)
  end

  it "can create a leaderboard" do
    visit("/admin/plugins/discourse-gamification")

    click_on(I18n.t("js.gamification.leaderboard.cta"))

    find(".new-leaderboard__name").fill_in(with: "My leaderboard")
    find(".new-leaderboard__create").click

    expect(find(".leaderboard-edit__name").value).to eq("My leaderboard")

    from_date_picker =
      PageObjects::Components::PikadayCalendar.new(".leaderboard-edit__from-date input")

    from_date_picker.select_date(
      Time.zone.now.year - 1,
      Time.zone.now.month - 1,
      Time.zone.now.end_of_month.day,
    )

    expect(from_date_picker).to be_hidden

    to_date_picker =
      PageObjects::Components::PikadayCalendar.new(".leaderboard-edit__to-date input")

    to_date_picker.select_date(
      Time.zone.now.year,
      Time.zone.now.month - 1,
      Time.zone.now.end_of_month.day,
    )

    expect(to_date_picker).to be_hidden

    included_groups_sk =
      PageObjects::Components::SelectKit.new("#leaderboard-edit__included-groups")
    included_groups_sk.expand
    included_groups_sk.select_row_by_name("admins")
    included_groups_sk.collapse

    excluded_groups_sk =
      PageObjects::Components::SelectKit.new("#leaderboard-edit__excluded-groups")
    excluded_groups_sk.expand
    excluded_groups_sk.select_row_by_name("trust_level_0")
    excluded_groups_sk.collapse

    find(".leaderboard-edit__save").click

    expect(page).to have_content(I18n.t("js.gamification.leaderboard.save_success"))

    expect(::DiscourseGamification::GamificationLeaderboard.last).to have_attributes(
      name: "My leaderboard",
      from_date: (Time.zone.now - 1.year).end_of_month.to_date,
      to_date: Time.zone.now.end_of_month.to_date,
      included_groups_ids: [Group::AUTO_GROUPS[:admins]],
      excluded_groups_ids: [Group::AUTO_GROUPS[:trust_level_0]],
    )
  end

  it "can edit a leaderboard" do
    leaderboard = Fabricate(:gamification_leaderboard, name: "Coolest duders")

    visit("/admin/plugins/discourse-gamification")

    # TODO (martin) We don't have a dedicated route for editing a leaderboard,
    # this will be added in a later PR.
    find("#leaderboard-admin__row-#{leaderboard.id} .leaderboard-admin__edit").click

    find(".leaderboard-edit__name").fill_in(with: "Coolest dudettes")
    find(".leaderboard-edit__save").click

    expect(page).to have_content(I18n.t("js.gamification.leaderboard.save_success"))

    expect(leaderboard.reload.name).to eq("Coolest dudettes")
  end

  it "can delete a leaderboard" do
    leaderboard = Fabricate(:gamification_leaderboard, name: "Coolest duders")

    visit("/admin/plugins/discourse-gamification")

    find("#leaderboard-admin__row-#{leaderboard.id} .leaderboard-admin__delete").click
    expect(page).to have_content(I18n.t("js.gamification.leaderboard.confirm_destroy"))

    find(".dialog-footer .btn-danger").click
    expect(page).to have_content(I18n.t("js.gamification.leaderboard.delete_success"))

    expect(::DiscourseGamification::GamificationLeaderboard.exists?(leaderboard.id)).to eq(false)
  end
end
