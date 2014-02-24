class AboutController < ApplicationController
  def team
    @members = [ 
                { "name" => "William Chidyausiku",
                  "bio" => "William is a Computer Science senior student at Stanford University.",
                  "img_url" => "/assets/William.png" },

                { "name" => "Veni Johanna",
                  "bio" => "Veni is a coterm student at Stanford University, majoring in Computer Science.",
                  "img_url" => "/assets/Veni.png" },
                   
                { "name" => "John Pulvera",
                  "bio" => "John is a Computer Science senior at Stanford University.",
                  "img_url" => "/assets/John.png" },
                   
                { "name" => "Stephen Quinonez",
                  "bio" => "Stephen is a Computer Science master student at Stanford University, with a bachelor in Philosophy.",
                  "img_url" => "/assets/Stephen.png" },

                { "name" => "Brett Solow",
                  "bio" => "Brett is a Computer Science senior student at Stanford University.",
                  "img_url" => "/assets/Brett.png" },


                   ]
  end
end
