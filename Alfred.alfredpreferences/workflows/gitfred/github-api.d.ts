// https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
declare class GithubNotif {
	id: string;
	repository: GithubRepo;
	subject: {
		title: string;
		url: string;
		// biome-ignore lint/style/useNamingConvention: not_by_me
		latest_comment_url: string;
		type: string;
	};
	reason: string;
	unread: boolean;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	updated_at: string;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	last_read_at: string | null;
	url: string;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	subscription_url: string;
}

declare class GithubIssue {
	title: string;
	user: { login: string };
	state: "open" | "closed";
	// biome-ignore lint/style/useNamingConvention: not_by_me
	state_reason?: "not_planned" | "completed";
	comments: number;
	draft: boolean;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	full_name: string;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	open_issues: number;
	number: string;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	html_url: string;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	repository_url: string;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	pull_request: { merged_at?: string };
	// biome-ignore lint/style/useNamingConvention: not_by_me
	created_at: string;
	// biome-ignore lint/style/useNamingConvention: not_by_me
	updated_at: string;
	labels: { name: string }[];
}

declare class GithubRepo {
	// biome-ignore lint/style/useNamingConvention: not_by_me
	full_name: string;
	name: string;
	description: string;
	owner: {
		login: string;
	};

	// biome-ignore lint/style/useNamingConvention: not_by_me
	html_url: string;
	homepage: string;

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
