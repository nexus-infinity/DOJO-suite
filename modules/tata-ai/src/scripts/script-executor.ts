import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export class ScriptExecutor {
  async execute(scriptPath: string): Promise<string> {
    try {
      const { stdout, stderr } = await execAsync(`node ${scriptPath}`);
      if (stderr) {
        console.error(`Script execution error: ${stderr}`);
      }
      return stdout;
    } catch (error) {
      console.error('Error executing script:', error);
      return 'An error occurred while executing the script.';
    }
  }
}
