import { useState } from 'react';
import { hasCompletedGuestTest } from '../api/guestSimulations';

const hasStoredSession = (): boolean => {
  try {
    return Boolean(localStorage.getItem('jwt_token'));
  } catch {
    return false;
  }
};

export const useHasCompletedGuestTest = (): boolean => {
  const [completed] = useState(() => !hasStoredSession() && hasCompletedGuestTest());

  return completed;
};
