# Download and install Node.js through nvm: https://nodejs.org/en/download
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh" # in lieu of restarting the shell
nvm install 22 # Jod is v22 LTS, `nvm ls-remote` gives full list

\. "$NVM_DIR/.nvm/nvm.sh" # in lieu of restarting the shell
# Install OpenSpec: https://github.com/Fission-AI/OpenSpec
npm install -g @fission-ai/openspec@latest

# # Install Spec-kit: https://github.com/github/spec-kit?tab=readme-ov-file#-get-started
# uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# # Install Gemini CLI: https://github.com/google-gemini/gemini-cli
# npm install -g @google/gemini-cli

# # Install OpenCode CLI: 
# npm i -g opencode-ai