// inside class Appointment
public void removeRoute(User user) {
    Calendar cal = user.getCalendar();
    
    this.route = null;
    cal.removeRoute(this.route);
}