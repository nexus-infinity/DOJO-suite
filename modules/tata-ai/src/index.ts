import { AIService } from './integrations/ai-service';
import { TataCore } from './core/tata-core';
import { ScriptExecutor } from './scripts/script-executor';
import { FileManager } from './file-management/file-manager';

export class TataAI {
  private aiService: AIService;
  private tataCore: TataCore;
  private scriptExecutor: ScriptExecutor;
  private fileManager: FileManager;

  constructor() {
    this.aiService = new AIService();
    this.tataCore = new TataCore();
    this.scriptExecutor = new ScriptExecutor();
    this.fileManager = new FileManager();
  }

  async generateText(prompt: string): Promise<string> {
    return this.aiService.generateText(prompt);
  }

  async processWithTataCore(input: string): Promise<string> {
    return this.tataCore.process(input);
  }

  async executeScript(scriptPath: string): Promise<string> {
    return this.scriptExecutor.execute(scriptPath);
  }

  async manageFile(filePath: string, content: string): Promise<void> {
    return this.fileManager.writeFile(filePath, content);
  }
}

export { AIService } from './integrations/ai-service';
export { TataCore } from './core/tata-core';
export { ScriptExecutor } from './scripts/script-executor';
export { FileManager } from './file-management/file-manager';
