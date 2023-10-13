declare class GithubRepo {
	// biome-ignore lint/style/useNamingConvention: not_by_me
	full_name: string;
	name: string;
	description: string;
	owner: {
		login: string;
	}

	// biome-ignore lint/style/useNamingConvention: not_by_me
	html_url: string;

	fork: boolean;
	archived: boolean;
	private: boolean;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	is_template: boolean;

	// biome-ignore lint/style/useNamingConvention: not_by_me
	pushed_at: string;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	stargazers_count: number;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	open_issues: number;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	forks_count: number;
}
