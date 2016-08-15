require 'rails_helper'

describe "Task volunteer and decline spec", js: true do

  let(:circle)    { create(:circle, :with_admin) }
  let(:admin)     { circle.admin }

  let(:working_group) { create(:working_group, circle: circle, member: admin) }
  let!(:task) { create(:task, working_group: working_group) }

  let(:task_page) { PageObject::Task::Page.new }

  describe "volunteering for a task" do
    context "when on the task page" do
      before { task_page.load_for(task, as: admin) }

      it "works" do
        task_page.volunteer_button.click
        expect(task_page).to have_decline_button
        expect(task_page).not_to have_volunteer_button
        expect(task_page.helper_names).to include(admin.name)
      end
    end
  end

  describe "declining from a task" do
    context "when on the task page" do

      before { task_page.load_for(task, as: admin) }

      context "when already volunteered" do

        before { task_page.volunteer_button.click }

        it "works" do
          task_page.decline_button.click
          expect(task_page).to have_volunteer_button
          expect(task_page).not_to have_decline_button
          expect(task_page.helper_names).not_to include(admin.name)
        end
      end

    end
  end

end