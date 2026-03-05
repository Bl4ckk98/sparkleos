// Timer per logout screen SparkleOS
var logoutTimer = {
    countdown: 30,
    
    start: function() {
        this.countdown = 30;
        this.interval = setInterval(function() {
            this.countdown--;
            if (this.countdown <= 0) {
                clearInterval(this.interval);
            }
        }.bind(this), 1000);
    },
    
    stop: function() {
        if (this.interval) {
            clearInterval(this.interval);
        }
    }
};
