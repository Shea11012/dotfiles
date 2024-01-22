# dotfiles

使用chezmoi管理dotfiles

# chezmoi 使用

`chezmoi init {git-url}`：初始化一个chezmoi仓库，如果已经有了仓库，则将git地址填入会自动pull下来
`chezmoi cd`：进入到仓库目录 `chezmoi add`：添加一个文件或目录到仓库
`chezmoi diff`：对比文件区别，以chezmoi仓库的文件为基准
`chezmoi apply`：将仓库文件修改更新对应的配置文件
