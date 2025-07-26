enum RunStatus {
  queued,
  inProgress,
  requiresAction,
  cancelling,
  canceled,
  failed,
  completed,
  incomplete,
  expired;

  static RunStatus fromJson(String value) {
    switch (value) {
      case 'queued':
        return RunStatus.queued;
      case 'in_progress':
        return RunStatus.inProgress;
      case 'requires_action':
        return RunStatus.requiresAction;
      case 'cancelling':
        return RunStatus.cancelling;
      case 'cancelled': // note: spelling
        return RunStatus.canceled;
      case 'failed':
        return RunStatus.failed;
      case 'completed':
        return RunStatus.completed;
      case 'incomplete':
        return RunStatus.incomplete;
      case 'expired':
        return RunStatus.expired;
      default:
        throw Exception('Unknown RunStatus: $value');
    }
  }

  String toJson() {
    switch (this) {
      case RunStatus.queued:
        return 'queued';
      case RunStatus.inProgress:
        return 'in_progress';
      case RunStatus.requiresAction:
        return 'requires_action';
      case RunStatus.cancelling:
        return 'cancelling';
      case RunStatus.canceled:
        return 'cancelled';
      case RunStatus.failed:
        return 'failed';
      case RunStatus.completed:
        return 'completed';
      case RunStatus.incomplete:
        return 'incomplete';
      case RunStatus.expired:
        return 'expired';
    }
  }
}