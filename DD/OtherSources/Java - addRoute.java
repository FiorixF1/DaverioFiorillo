// inside class Appointment
public void addRoute(User user, Route route) {
    Calendar cal = user.getCalendar();
    DateTime begin = route.getStart().getStartTime();
    DateTime end = route.getEnd().getEndTime();
    
    if (checkOverlapping(cal, this, begin, end)) {
        this.route = route;
        cal.insertRoute(route);
    } else {
        throw new OverlappingException();
    }
}