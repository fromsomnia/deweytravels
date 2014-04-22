class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.references :inviter, index: true
      t.references :group, index: true
      t.string :invite_code

      t.timestamps
    end
  end
end
