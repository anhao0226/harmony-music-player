/**
 *
 * @param duration
 * @returns
 */
export function formatDuration(duration: number): string {
  let minute: number = Math.floor(duration / 60);
  let seconds = Math.floor(duration % 60);
  return `${new String(minute).padStart(2, '0')}:${new String(seconds).padStart(2, '0')}`;
}