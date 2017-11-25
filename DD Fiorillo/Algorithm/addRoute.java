// inside class Appointment
public void addRoute(User user, Route route) {
    Calendar cal = user.getCalendar();
    DateTime begin = route.getStart().getStartTime();
    DateTime end = route.getEnd().getEndTime();
    
    if (checkOverlapping(cal, this, begin, end)) {
        // TODO: decide if the appointment itself adds its own route or the calendar does it inside insertRoute
        // so that we have the updating of the route in one point
        this.route = route;
        cal.insertRoute(route);
    } else {
        throw new OverlappingException();
    }
}