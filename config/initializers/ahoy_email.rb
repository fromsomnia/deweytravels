class EmailSubscriber

  def open(event)
    mixpanel.track 'email_opened', {
      :message_id => event[:message].id
    }
  end

  def click(event)
    mixpanel.track "email_clicked", {
      :message_id => event[:message].id,
      :url => event[:url]
    }
  end

end

AhoyEmail.subscribers << EmailSubscriber.new
