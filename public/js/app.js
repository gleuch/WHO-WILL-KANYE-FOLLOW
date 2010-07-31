var wwkf = {
  
  values : {
    maxChars: 140,
    tweetName: 'wwkf',
    targetName: 'kanyewest',
    initTweet: '',
    appendTweet: '#wwkf http://whowillkanyefollow.com',
    init: false
  },

  init : function() {
    var updateChar = function() {wwkf.updateCharLimit();}, updateTweetName = function() {wwkf.updateTweetName();}

    $('#person_tweet').val(this.values.initTweet.strip()).change(updateChar).keyup(updateChar).focusin(updateChar).focusout(updateChar);
    $('#person_appendTweet').html(this.values.appendTweet.strip());
    $('#actual_tweet').val(this.values.initTweet.strip() + ' ' + this.values.appendTweet.strip());
    $('.person_screen_name').html(this.values.tweetName.strip());
    $('#person_screen_name').val(this.values.tweetName.strip()).change(updateTweetName).keyup(updateTweetName).focusin(updateTweetName).focusout(updateTweetName);

    $('#vote_form_box').submit(function() {return wwkf.checkSubmit();});

    this.updateTweetName();
    this.updateCharLimit();
    this.values.init = true;
  },

  updateCharLimit : function() {
    var charsLeft = this.values.maxChars - $('#person_tweet').val().strip().length - this.values.appendTweet.strip().length - 1;
    /* TODO : Make shades of red when close to 0 */
    $('#follow_tweet .charsleft').html(charsLeft);
  },

  updateTweetName : function() {
    var tweetName = $('#person_screen_name').val().strip(), tweetMsg = $('#person_tweet').val().strip(), regexp_name = new RegExp('\@'+ this.values.tweetName.toLowerCase(), 'im');

    if (tweetName != '' && tweetName.toLowerCase() != this.values.targetName.toLowerCase()) {
      if (tweetMsg.match(regexp_name)) {
        tweetMsg = tweetMsg.replace(regexp_name, '@'+tweetName)
      } else {
        tweetMsg += ' @'+ tweetName;
      }
      $('#person_tweet').val(tweetMsg.strip());
      this.values.tweetName = tweetName;
      $('.person_screen_name').html(this.values.tweetName);
      this.updateCharLimit();
    }
  },

  checkSubmit : function() {
    this.updateTweetName();

    $('#actual_tweet').val($('#person_tweet').val().strip() + ' ' + this.values.appendTweet.strip());

    var charsLeft = this.values.maxChars - $('#actual_tweet').val().strip().length;
    if (charsLeft < 0) {
      alert('Your tweet must be 140 characters or less.');
      return false;
    }
    
    return true;
  }

};


String.prototype.strip = function() {return this.replace(/^([\n\r\s ]+)/, '').replace(/([\n\r\s ]+)$/, '');};