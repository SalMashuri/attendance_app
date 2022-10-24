class WorkLocation {
  String workkey;
  int workval;

  WorkLocation(this.workkey, this.workval);

  @override
  String toString() {
    return '{ ${this.workkey}, ${this.workval} }';
  }
}